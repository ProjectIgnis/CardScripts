--プライム・ドワーフ
--Prime Dwarf
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local params={aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),Fusion.OnFieldMat(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT)),s.fextra}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT)),tp,0,LOCATION_ONFIELD,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,0)
end
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetRace)==#sg
end
function s.operation(oldtg,oldop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.HintSelection(g,true)
		if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
		local tdg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
		if aux.SelectUnselectGroup(tdg,e,tp,3,3,s.rescon,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local cg=aux.SelectUnselectGroup(tdg,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK)
			Duel.HintSelection(cg,true)
			if Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
			if oldtg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				oldop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end