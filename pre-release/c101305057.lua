--ＲＵＭ－幻影騎士団レクイエム
--The Phantom Knights' Rank-Up-Magic Requiem
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 "The Phantom Knights" or "Xyz Dragon" monster in your GY or banishment; Special Summon it (but negate its effects), then Special Summon from your Extra Deck, 1 "The Phantom Knights" or "Xyz Dragon" Xyz Monster that is 1 Rank higher than a DARK Xyz Monster you control, by using that monster as material (this is treated as an Xyz Summon, transfer its materials)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_THE_PHANTOM_KNIGHTS,SET_XYZ_DRAGON}
function s.fieldxyzfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if not (#pg==0 or (#pg==1 and pg:IsContains(c))) then return false end
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzMonster() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.xyzspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
end
function s.xyzspfilter(c,e,tp,mc,rank)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsSetCard({SET_THE_PHANTOM_KNIGHTS,SET_XYZ_DRAGON}) and c:IsXyzMonster() and c:IsRank(rank) and mc:IsCanBeXyzMaterial(c,tp)
		and mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.gybanspfilter(c,e,tp,field_xyz_chk)
	return c:IsSetCard({SET_THE_PHANTOM_KNIGHTS,SET_XYZ_DRAGON}) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (field_xyz_chk or s.fieldxyzfilter(c,e,tp))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local field_xyz_chk=Duel.IsExistingMatchingCard(s.fieldxyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.gybanspfilter(chkc,e,tp,field_xyz_chk) end
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gybanspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,field_xyz_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gybanspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,field_xyz_chk)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
		if Duel.SpecialSummonComplete()==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mc=Duel.SelectMatchingCard(tp,s.fieldxyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
		if not mc then return end
		Duel.HintSelection(mc)
		if mc:IsImmuneToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc,mc:GetRank()+1):GetFirst()
		if xyz then
			xyz:SetMaterial(mc)
			Duel.Overlay(xyz,mc)
			Duel.BreakEffect()
			if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				xyz:CompleteProcedure()
			end
		end
	end
end