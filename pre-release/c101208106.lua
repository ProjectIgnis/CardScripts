--アコード・トーカー＠イグニスター
--Accode Talker @Ignister
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 3+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--Special Summon as many Cyberse monsters with 2300 ATK from your GY as possible to your zones this card points to
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Negate the activation of an opponent's card or effect, and if you do, banish that card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsAttack(2300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLinkedZone(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if c:IsRelateToEffect(e) and c:IsFaceup() and zone>0 and ft>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,ft,ft,nil,e,tp,zone)
		if #g>0 then
			local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
			if ct>0 then
				c:UpdateAttack(ct*500)
			end
		end
	end
	--You cannot Special Summon for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.negcostfilter(c,lg)
	return c:IsLinkMonster() and lg:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return #lg>0 and Duel.CheckReleaseGroupCost(tp,s.negcostfilter,1,false,nil,nil,lg) end
	local g=Duel.SelectReleaseGroupCost(tp,s.negcostfilter,1,1,false,nil,nil,lg)
	Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end