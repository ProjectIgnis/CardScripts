--サイバースパイス・ナツメグ
--Cybersepice Nutmeg
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--Gain LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.otfilter(c)
	return c:IsRace(RACE_CYBERSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
	local g2=Duel.GetOperatedGroup()
	g:Merge(g2)
	local tdg=g:Filter(Card.IsAbleToDeck,nil)
	if #tdg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=tdg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		if opt==0 then
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		elseif opt==1 then
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
