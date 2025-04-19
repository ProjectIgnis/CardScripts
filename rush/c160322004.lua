--ハーピィ・レジーナ・ＳＡ
--Harpie Regina Splendid Armor
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160208008,1,s.ffilter,1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Change monster's battle position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160208008}
s.named_material={160208008}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WINGEDBEAST,fc,sumtype,tp) and c:IsLevelBelow(4)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.HintSelection(g)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160210070)
		and Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.HintSelection(g)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end