--スパイ・オブザベイション
--Spy Observation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.cfilter),tp,LOCATION_MZONE,0,2,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) end
	Duel.SetTargetPlayer(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,1)
	local g=Duel.GetDecktopGroup(p,1)
	if Duel.SelectOption(p,aux.Stringid(id,1),aux.Stringid(id,2))==1 then
		Duel.MoveToDeckBottom(g)
		Duel.SortDeckbottom(p,p,#g)
	else
		Duel.SortDecktop(p,p,#g)
	end
	local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=dg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end