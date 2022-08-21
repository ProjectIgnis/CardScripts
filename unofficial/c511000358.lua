--奇跡の逆鱗
--Miracle of Draconian Wrath
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	local prev_loc_mzone=c:IsPreviousLocation(LOCATION_MZONE)
	return (prev_loc_mzone and c:GetPreviousRaceOnField()&RACE_DRAGON>0)
		or (not prev_loc_mzone and c:IsOriginalRace(RACE_DRAGON))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>1 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,2,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end