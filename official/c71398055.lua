--ＤＤＤＤ偉次元王アーク・クライシス
--D/D/D/D Dimensional King Arc Crisis
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--Fusion Materials: 4 Fiend monsters (1 Fusion, 1 Synchro, 1 Xyz, 1 Pendulum)
	Fusion.AddProcMix(c,true,true,s.matfilter(TYPE_FUSION),s.matfilter(TYPE_SYNCHRO),s.matfilter(TYPE_XYZ),s.matfilter(TYPE_PENDULUM))
	c:AddMustBeFusionSummoned()
	--Special Summon this card (from your Extra Deck) by banishing the above materials from your field and/or GY
	Fusion.AddContactProc(c,s.contactfil,s.contactop,false,nil,1)
	--You can only Fusion Summon or Special Summon by its alternate procedure "D/D/D/D Dimensional King Arc Crisis" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Destroy "Dark Contract" cards you control to Special Summon "Doom King" monsters from your Deck/Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Negate the effects of all face-up monsters your opponent currently controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Can attack all monsters your opponent controls once each
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Place this card in your Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.CheckPendulumZones(tp) end end)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DARK_CONTRACT,SET_DOOM_KING}
s.miracle_synchro_fusion=true
function s.matfilter(typ)
	return function(c,fc,sumtype,tp)
		return c:IsRace(RACE_FIEND,fc,sumtype,tp) and c:IsType(typ,fc,sumtype,tp)
	end
end
function s.contactfil(tp)
	local loc=LOCATION_MZONE|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_MZONE end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent another Fusion Summon or Special Summon by its alternate procedure of "D/D/D/D Great Dimension King Arc Crisis" that turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.desfilter(c,e,tp)
	return c:IsSetCard(SET_DARK_CONTRACT) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,dc)
end
function s.spfilter(c,e,tp,dc)
	if not (c:IsSetCard(SET_DOOM_KING) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	return (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,dc)>0) or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,dc,c)>0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCountFromEx(tp,tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and chkc:IsFaceup() and s.desfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	local ct=Duel.GetMatchingGroupCount(s.desfilter,tp,LOCATION_ONFIELD,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,ct,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.rescon(mmz_ct,linkmz_ct)
	return	function(sg,e,tp,mg)
				return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=mmz_ct
					and sg:FilterCount(aux.FaceupFilter(Card.IsLocation,LOCATION_EXTRA),nil)<=linkmz_ct
			end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if tg==0 then return end
	local ct=Duel.Destroy(tg,REASON_EFFECT)
	if ct==0 then return end
	local mmz_ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local emz_ct=Duel.GetLocationCountFromEx(tp,tp,nil,nil,ZONES_EMZ)
	local linkmz_ct=Duel.GetLocationCountFromEx(tp,tp)
	local ft=math.min(mmz_ct+emz_ct,ct)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(mmz_ct,linkmz_ct),1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end
	local fup,fdown=sg:Split(aux.FaceupFilter(Card.IsLocation,LOCATION_EXTRA),nil)
	local fdown_main,fdown_ex=fdown:Split(Card.IsLocation,nil,LOCATION_DECK)
	local priority_0,priority_1
	if linkmz_ct<mmz_ct then
		priority_0=fup
		priority_1=fdown_main
	else
		priority_0=fdown_main
		priority_1=fup
	end
	for prio0_c in priority_0:Iter() do
		Duel.SpecialSummonStep(prio0_c,0,tp,tp,false,false,POS_FACEUP)
	end
	for prio1_c in priority_1:Iter() do
		Duel.SpecialSummonStep(prio1_c,0,tp,tp,false,false,POS_FACEUP)
	end
	for fdown_ex_c in fdown_ex:Iter() do
		Duel.SpecialSummonStep(fdown_ex_c,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.BreakEffect()
	Duel.SpecialSummonComplete()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Negate their effects
		tc:NegateEffects(c)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
