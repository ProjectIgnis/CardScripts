--マジェスティ・オブ・セブンスロード
--Majesty of the Sevens Road
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160008032,160418002)
	--Destroy 1 card your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160008032}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,1,nil)
	local dg2=dg:AddMaximumCheck()
	Duel.HintSelection(dg2)
	if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160008032)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,1,nil)
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if #g>1 then
			Duel.SortDeckbottom(1-tp,1-tp,#g)
		end
	end
end