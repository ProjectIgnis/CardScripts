--Ｒｅｃｅｔｔｅ ｄｅ Ｐｏｉｓｓｏｎ～魚料理のレシピ～
--Recette de Poisson - Fish Recipe
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	-- Ritual Summon any "Nouvellez" monster
	local e1=Ritual.AddProcGreater({handler=c,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_NOUVELLEZ),
		stage2=s.stage2,extratg=s.extratg})
	e1:SetCategory(e1:GetCategory()|CATEGORY_SEARCH|CATEGORY_TOHAND)
end
s.listed_series={SET_RECIPE,SET_NOUVELLEZ}
s.listed_names={id,100430029} --Buerillabaisse de Nouvellez
function s.thfilter(c)
	return c:IsSetCard(SET_RECIPE) and c:IsRitualSpell() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	if not tc:IsCode(100430029) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE|LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_DECK)
end