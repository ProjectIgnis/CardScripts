--覇王の逆鱗
--Supreme Rage
local s,id=GetID()
function s.initial_effect(c)
	--Destroy as many monsters you control as possible, and if you do, Special Summon up to 4 "Supreme King Dragon" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Attach 2 "Supreme King Dragon" monsters to 1 "Supreme King Dragon" Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SUPREME_KING_DRAGON}
s.listed_names={CARD_ZARC}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ZARC),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(SET_SUPREME_KING_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	local g=Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode,CARD_ZARC)),tp,LOCATION_MZONE,0,nil)
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,g,c)>0
	else
		return Duel.GetMZoneCount(tp,g)>0
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode,CARD_ZARC)),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsCode,CARD_ZARC)),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.exfilter1(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ)
end
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.rescon(ft1,ft2,ft3,ft4,ft)
	return	function(sg,e,tp,mg)
				local exnpct=sg:FilterCount(s.exfilter1,nil,LOCATION_EXTRA)
				local expct=sg:FilterCount(s.exfilter2,nil,LOCATION_EXTRA)
				local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
				local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
				local groupcount=#sg
				local classcount=sg:GetClassCount(Card.GetCode)
				local res=ft3>=exnpct and ft4>=expct and ft1>=mct and ft>=groupcount and classcount==groupcount
				return res, not res
			end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode,CARD_ZARC)),tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	local ft4=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	local ft=math.min(Duel.GetUsableMZoneCount(tp),4)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		if ft4>0 then ft4=1 end
		ft=1
	end
	local ect=aux.CheckSummonGate(tp)
	if ect then
		ft1 = math.min(ect, ft1)
		ft2 = math.min(ect, ft2)
		ft3 = math.min(ect, ft3)
		ft4 = math.min(ect, ft4)
	end
	local loc=0
	if ft1>0 then loc=loc|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE end
	if ft2>0 or ft3>0 or ft4>0 then loc=loc|LOCATION_EXTRA end
	if loc==0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,loc,0,nil,e,tp)
	if #sg==0 then return end
	local rg=aux.SelectUnselectGroup(sg,e,tp,1,ft,s.rescon(ft1,ft2,ft3,ft4,ft),1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)
end
function s.xyzfilter(c,tp)
	return c:IsSetCard(SET_SUPREME_KING_DRAGON) and c:IsType(TYPE_XYZ) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,2,nil,tp,c)
end
function s.matfilter(c,tp,xyzc)
	return c:IsSetCard(SET_SUPREME_KING_DRAGON) and c:IsMonster()
		and c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,2,2,nil,tp,tc)
		if #g>0 then
			Duel.Overlay(tc,g)
		end
	end
end