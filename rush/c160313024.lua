--ギャラクティカ・リパルジョン
--Galactica Repulsion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:IsType(TYPE_NORMAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)>=3
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local dg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #dg>0 then
		dg=dg:AddMaximumCheck()
		Duel.HintSelection(dg,true)
		Duel.SendtoHand(dg,nil,REASON_EFFECT) 
	end
end
