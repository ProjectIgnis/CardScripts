--TCB
--Type Change Beam
local s,id=GetID()
function s.initial_effect(c)
	--Change the Race for up to 3 of monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.rvfilter(c,tp)
	return c:IsMonster() and not c:IsPublic()
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.attfilter,c:GetRace()),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.attfilter(c,race)
	return c:IsFaceup() and c:IsMonster() and c:CanChangeIntoTypeRush(race)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tg=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if not tg then return end
	Duel.ConfirmCards(1-tp,tg)
	Duel.ShuffleHand(tp)
	if Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.attfilter,tg:GetRace()),tp,LOCATION_MZONE,LOCATION_MZONE,nil,tg:GetAttribute())>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.attfilter,tg:GetRace()),tp,LOCATION_MZONE,LOCATION_MZONE,1,3,nil,tg:GetAttribute())
		if #g>0 then
			Duel.HintSelection(g,true)
			local race=tg:GetRace()
			for tc in g:Iter() do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_RACE)
				e1:SetValue(race)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end