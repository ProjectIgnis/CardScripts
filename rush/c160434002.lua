--ジョインテック・レオ
--Jointech Leo
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.setfilter(c,tp)
	return c:IsSpellTrap() and c:IsSSetable(false, 1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
end
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(7) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	if #g>0 then
		Duel.SSet(1-tp,g)
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g2>0 then
				Duel.HintSelection(g2,true)
				Duel.BreakEffect()
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
			end
		end
	end
end
