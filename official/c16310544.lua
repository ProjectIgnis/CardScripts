--御巫神楽
--Mikanko Kagura
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.AddProcGreater({
		handler=c,
		filter=aux.FilterBoolFunction(Card.IsSetCard,SET_MIKANKO),
		stage2=s.stage2
	})
	e1:SetCategory(e1:GetCategory()|CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
end
s.listed_series={SET_MIKANKO}
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if #g==0 then return end
	local eg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_EQUIP)
	local ct=eg:GetClassCount(Card.GetCode)
	if ct==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=g:Select(tp,1,ct,nil)
	if #dg==0 then return end
	Duel.HintSelection(dg,true)
	Duel.BreakEffect()
	local des=Duel.Destroy(dg,REASON_EFFECT)
	if des>0 then
		Duel.Damage(1-tp,des*1000,REASON_EFFECT)
	end
end