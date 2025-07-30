--真竜凰騎マリアムネＰ
--Mariamne Paradox, the True Dracophoenix Knight
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--To Tribute Summon this card face-up, you can Tribute a Continuous Spell/Trap you control, instead of a monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_SZONE,0)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsContinuousSpellTrap))
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--Destroy 1 other "True Draco" or "True King" card in your hand or face-up field, and if you do, Special Summon this card to either field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Banish the top 4 cards of your Deck
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_REMOVE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_HAND) end)
	e2a:SetTarget(s.rmtg)
	e2a:SetOperation(s.rmop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_TRUE_DRACO_KING}
function s.desfilter(c,e,tp,hc,resolution_chk)
	return c:IsSetCard(SET_TRUE_DRACO_KING)	and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (resolution_chk or s.spcheck(c,e,tp,hc))
end
function s.spcheck(c,e,tp,hc)
	local ctrl=c:GetControler()
	return (Duel.GetMZoneCount(ctrl,c,tp)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,ctrl))
		or (Duel.GetMZoneCount(1-ctrl,nil,tp)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-ctrl))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local oppo_location=Duel.IsPlayerAffectedByEffect(tp,88581108) and LOCATION_MZONE or 0
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,oppo_location,c,e,tp,c,false)
	if chk==0 then return #g>0 end
	if not g:IsExists(Card.IsOnField,1,nil) or ((Duel.GetMZoneCount(tp)>0 or Duel.GetMZoneCount(1-tp)>0)
		and (Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,LOCATION_HAND,0,1,c)
		or g:IsExists(aux.FaceupFilter(Card.IsLocation,LOCATION_HAND),1,nil))) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local relation_chk=c:IsRelateToEffect(e)
	local exc=relation_chk and c or nil
	local oppo_location=Duel.IsPlayerAffectedByEffect(tp,88581108) and LOCATION_MZONE or 0
	local resolution_chk=not (relation_chk and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,oppo_location,1,exc,e,tp,c,false))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sc=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,oppo_location,1,1,exc,e,tp,c,resolution_chk):GetFirst()
	if not sc then return end
	if sc:IsOnField() then Duel.HintSelection(sc) end
	if Duel.Destroy(sc,REASON_EFFECT)>0 and relation_chk then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		if not (b1 or b2) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
		local target_player=op==1 and tp or 1-tp
		Duel.SpecialSummon(c,0,tp,target_player,false,false,POS_FACEUP)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetDecktopGroup(tp,4)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,4)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end