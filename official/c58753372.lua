--超量妖精アルファン
--Super Quantal Fairy Alphan
local s,id=GetID()
function s.initial_effect(c)
	--lv
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0xdc}
function s.filter1(c)
	return c:IsFaceup() and c:HasLevel()
end
function s.filter2(c,tp)
	return s.filter1(c) and c:IsSetCard(0xdc)
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter2(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil,tp) and g1:GetClassCount(Card.GetLevel)>1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,tc)
		local lc=g:GetFirst()
		local lv=tc:GetLevel()
		for lc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
		end
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c)
	return c:IsSetCard(0xdc) and c:IsType(TYPE_MONSTER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		return ft>0 and g:GetClassCount(Card.GetCode)>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		local cg=Group.CreateGroup()
		for i=1,3 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
			cg:Merge(sg)
		end
		Duel.ConfirmCards(1-tp,cg)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local tg=cg:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			cg:RemoveCard(tc)
		end
		Duel.SendtoGrave(cg,REASON_EFFECT)
	end
end
