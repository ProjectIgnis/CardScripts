--超重武者タマ－C
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
end
s.listed_series={0x9a}
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x9a)
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
function s.filter(c,e,tp,lv)
	return c:IsFaceup() and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+c:GetOriginalLevel())
end
function s.scfilter(c,e,tp,lv)
	return c:IsSetCard(0x9a) and c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local lv=e:GetHandler():GetOriginalLevel()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp,lv)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or #pg>0 then return end
	local g=Group.FromCards(c,tc)
	if Duel.SendtoGrave(g,REASON_EFFECT)==2 and c:GetLevel()>0 and c:IsLocation(LOCATION_GRAVE)
		and tc:GetLevel()>0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=c:GetLevel()+tc:GetLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		local tc=sg:GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
