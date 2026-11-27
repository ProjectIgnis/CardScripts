--終天獄神Ωヴィードリウム
--Omega Vidolium the Power Patron of Heaven's End
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--Fusion Materials: 3 monsters Special Summoned from the Extra Deck with 3000 or more ATK
	Fusion.AddProcMixN(c,true,true,s.matfilter,3)
	c:AddMustFirstBeFusionSummoned()
	--If a monster(s) is Special Summoned from the Extra Deck: You can return this card to the Extra Deck, then you can Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from either field, including a "Power Patron" monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.toextracon)
	e1:SetTarget(s.toextratg)
	e1:SetOperation(s.toextraop)
	c:RegisterEffect(e1)
	--Unaffected by card effects, except "Power Patron" cards'
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,te)
		return not te:IsCardSetcode(SET_POWER_PATRON)
	end)
	c:RegisterEffect(e2)
	--When your opponent activates a monster effect while they control 2 or more monsters with the same Type as that monster (Quick Effect): You can banish (face-down) the top 3 cards of your Deck; negate the activation, and if you do, banish that monster face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--Once per turn, during your Standby Phase: Place this card in your Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(tp)
	end)
	e4:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			if Duel.CheckPendulumZones(tp) then
				Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			else
				Duel.SendtoGrave(c,REASON_RULE,nil,PLAYER_NONE)
			end
		end
	end)
	c:RegisterEffect(e4)
end
s.listed_series={SET_POWER_PATRON}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAttackAbove(3000) and c:IsOnField()
end
function s.toextracon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA)
end
function s.toextratg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.powerpatronfilter(c,tp,fc)
	return c:IsSetCard(SET_POWER_PATRON,fc,SUMMON_TYPE_FUSION,tp) and c:IsControler(tp)
end
function s.fuscheck(tp,sg,fc)
	return sg:IsExists(s.powerpatronfilter,1,nil,tp,fc)
end
function s.extramaterial(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.fuscheck
end
function s.toextraop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA) then
		local fusion_params={
			matfilter=Fusion.OnFieldMat,
			extrafil=s.extramaterial
		}
		if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)) or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local trig_race=Chain.GetTriggeringRace(ev)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,trig_race),tp,0,LOCATION_MZONE,2,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:IsExists(Card.IsAbleToRemoveAsCost,3,nil,POS_FACEDOWN) end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
	end
end