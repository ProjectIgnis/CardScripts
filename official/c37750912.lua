--スターダスト・イルミネイト
--Stardust Illumination
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 "Stardust" monster from your Deck to the GY, or if you control "Stardust Dragon" or a Synchro Monster that mentions it, you can Special Summon it instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Increase or decrease the Level of 1 "Stardust" monster you control by 1 until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_STARDUST_DRAGON}
s.listed_series={SET_STARDUST}
function s.spconfilter(c)
	return (c:IsCode(CARD_STARDUST_DRAGON) or (c:ListsCode(CARD_STARDUST_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsMonster())) and c:IsFaceup()
end
function s.tgfilter(c,e,tp,stardust_mzone_chk)
	return c:IsSetCard(SET_STARDUST) and c:IsMonster() and (c:IsAbleToGrave() or (stardust_mzone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local stardust_mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,stardust_mzone_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local stardust_mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
	local hintmsg=stardust_mzone_chk and aux.Stringid(id,2) or HINTMSG_TOGRAVE
	Duel.Hint(HINT_SELECTMSG,tp,hintmsg)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,stardust_mzone_chk):GetFirst()
	if not sc then return end
	local op=1
	if stardust_mzone_chk then
		local b1=sc:IsAbleToGrave()
		local b2=sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	end
	if op==1 then
		Duel.SendtoGrave(sc,REASON_EFFECT)
	elseif op==2 then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.lvfilter(c)
	return c:IsSetCard(SET_STARDUST) and c:HasLevel() and c:IsFaceup()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,tc,1,tp,1)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:HasLevel() then
		local op=tc:IsLevelAbove(2) and Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6)) or 0
		local lv=op==0 and 1 or -1
		--Increase or decrease its Level by 1 until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
