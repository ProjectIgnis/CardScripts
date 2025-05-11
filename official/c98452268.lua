--覇王黒竜オッドアイズ・リベリオン・ドラゴン－オーバーロード
--Odd-Eyes Rebellion Dragon Overlord
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 monsters OR 1 "Rebellion" Xyz Monster you control
	Xyz.AddProcedure(c,nil,7,2,function(c) return c:IsSetCard(SET_REBELLION) and c:IsType(TYPE_XYZ) and c:IsFaceup() end,aux.Stringid(id,0))
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--You can only Special Summon "Odd-Eyes Rebellion Dragon Overlord(s)" once per turn
	c:SetSPSummonOnce(id)
	--Special Summon this card from your Pendulum Zone, then Special Summon from your Extra Deck, 1 "Rebellion" or "The Phantom Knights" monster, using this card as material (this is treated as an Xyz Summon), then you can attach 1 card from your Pendulum Zone to it as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--This card that was Xyz Summoned using a Rank 7 Xyz Monster as material can make up to 3 attacks during each Battle Phase
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetCode(EFFECT_EXTRA_ATTACK)
	e2a:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2a:SetValue(2)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetCode(EFFECT_MATERIAL_CHECK)
	e2b:SetValue(s.valcheck)
	c:RegisterEffect(e2b)
	--Place this card in your Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.CheckPendulumZones(tp) end end)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
s.pendulum_level=7
s.listed_names={id}
s.listed_series={SET_REBELLION,SET_THE_PHANTOM_KNIGHTS}
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard({SET_REBELLION,SET_THE_PHANTOM_KNIGHTS}) and c:IsType(TYPE_XYZ) and c:IsFacedown()
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and mc:IsCanBeXyzMaterial(c,tp) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (#pg<=0 or (#pg==1 and pg:IsContains(c)))
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		if not (#pg<=0 or (#pg==1 and pg:IsContains(c))) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
		if not sc then return end
		sc:SetMaterial(c)
		Duel.Overlay(sc,c)
		Duel.BreakEffect()
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
		sc:CompleteProcedure()
		if Duel.IsExistingMatchingCard(Card.IsCanBeXyzMaterial,tp,LOCATION_PZONE,0,1,nil,c,tp,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local matc=Duel.SelectMatchingCard(tp,Card.IsCanBeXyzMaterial,tp,LOCATION_PZONE,0,1,1,nil,c,tp,REASON_EFFECT):GetFirst()
			if not matc then return end
			Duel.HintSelection(matc)
			Duel.BreakEffect()
			Duel.Overlay(sc,matc)
		end
	end
end
function s.valcheckfilter(c)
	return c:IsRank(7) and c:IsType(TYPE_XYZ)
end
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(s.valcheckfilter,1,nil) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
