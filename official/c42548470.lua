--揺れる発条秤
--Weights & Zenmaisures
local s,id=GetID()
function s.initial_effect(c)
	--Change the level of 1 "Wind-up" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WIND_UP}
function s.filter(c,e)
	return c:IsFaceup() and c:IsSetCard(SET_WIND_UP) and c:HasLevel() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg)
	return sg:GetClassCount(Card.GetLevel)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,tg,1,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #g==2 and g:GetClassCount(Card.GetLevel)==2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,1))
		local tc1=g:Select(1-tp,1,1,nil):GetFirst()
		local tc2=g:RemoveCard(tc1):GetFirst()
		local lv1=tc1:GetLevel()
		local lv2=tc2:GetLevel()
		--Change the other monsters level to match the selected monster's
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc2:RegisterEffect(e1)
		if lv1<lv2 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end