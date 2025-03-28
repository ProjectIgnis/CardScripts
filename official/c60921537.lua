--凶導の葬列
--Dogmatikamacabre
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.AddProcGreater({
		handler=c,
		filter=aux.FilterBoolFunction(Card.IsSetCard,SET_DOGMATIKA),
		location=LOCATION_HAND|LOCATION_GRAVE,
		extrafil=s.extramat,
		extratg=s.extratg,
		stage2=s.stage2
	})
	e1:SetCategory(e1:GetCategory()+CATEGORY_TOGRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_names={40352445,48654323}
s.listed_series={SET_DOGMATIKA}
function s.matfilter(c)
	return c:HasLevel() and c:IsType(TYPE_FUSION|TYPE_SYNCHRO) and c:IsAbleToRemove()
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION)
		and Group.NewGroup() or Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_EITHER,LOCATION_EXTRA)
end
function s.onfield(code)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,code),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	if not (s.onfield(40352445) and s.onfield(48654323)) then return end
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if (#g1<1 and #g2<1) or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local op=Duel.SelectEffect(tp,
		{#g1>0,aux.Stringid(id,1)},
		{#g2>0,aux.Stringid(id,2)})
	local g=(op==1) and g1 or g2
	if op==2 then Duel.ConfirmCards(tp,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:FilterSelect(tp,aux.AND(Card.IsMonster,Card.IsAbleToGrave),1,1,nil)
	if #tg>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(tg,REASON_EFFECT)
		if op==2 then Duel.ShuffleExtra(1-tp) end
	end
end