--サプライズ・チェーン
--Surprise Chain
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)>0 and Duel.CheckChainUniqueness()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cl=Duel.GetCurrentChain()
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=cl
		and (cl<3 or Duel.IsPlayerCanDiscardDeck(tp,1))
		and (cl<4 or Duel.IsPlayerCanDraw(tp,1))
	end
	if cl>=3 then Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK) end
	if cl>=4 then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local cl=Duel.GetCurrentChain()
	if cl>=2 then
		Duel.SortDecktop(tp,tp,cl)
	end
	if cl>=3 and Duel.IsPlayerCanDiscardDeck(tp,1) then
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
	if cl>=4 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end