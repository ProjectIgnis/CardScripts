-- 凶導の葬列
-- Dogmatikabre
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Ritual Summon
	local e1=Ritual.AddProcGreater({
		handler=c,
		filter=aux.FilterBoolFunction(Card.IsSetCard,0x146),
		extrafil=s.extramat,
		stage2=s.stage2
	})
	e1:SetCategory(e1:GetCategory()+CATEGORY_TOGRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- Negatable by "Ghost Belle and Haunted Mansion"
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_names={40352445,101107035}
s.listed_series={0x146}
function s.matfilter(c)
	return c:HasLevel() and c:IsType(TYPE_FUSION|TYPE_SYNCHRO) and c:IsAbleToRemove()
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsPlayerAffectedByEffect(tp,69832741)
		and Group.NewGroup() or Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.onfield(code)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,code),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	if not s.onfield(40352445) or not s.onfield(101107035) then return end
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if (#g1<1 and #g2<1) or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local op=aux.SelectEffect(tp,
		{#g1>0,aux.Stringid(id,1)},
		{#g2>0,aux.Stringid(id,2)})
	local g=(op==1) and g1 or g2
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:FilterSelect(tp,aux.AND(Card.IsMonster,Card.IsAbleToGrave),1,1,nil)
	if #tg>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(tg,REASON_EFFECT)
		if op==2 then Duel.ShuffleExtra(1-tp) end
	end
end