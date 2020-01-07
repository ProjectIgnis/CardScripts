--獣神機王バルバロスUr
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--no battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
function s.spfilter(c,rac)
	return c:IsRace(rac) and c:IsAbleToRemoveAsCost() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) 
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true,true))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local n=0
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,c,RACE_BEASTWARRIOR) then n=n-1 end
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,c,RACE_MACHINE) then n=n-1 end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>n
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0x16,0,1,c,RACE_BEASTWARRIOR)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0x16,0,1,c,RACE_MACHINE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=nil
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft~=0 then
		local loc=0x16
		if ft<0 then loc=LOCATION_MZONE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,c,RACE_BEASTWARRIOR)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,c,RACE_MACHINE)
		g1:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,c,RACE_BEASTWARRIOR+RACE_MACHINE)
		local rc=RACE_BEASTWARRIOR
		if g1:GetFirst():IsRace(RACE_BEASTWARRIOR) then rc=RACE_MACHINE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,0x16,0,1,1,c,rc)
		g1:Merge(g2)
	end
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
