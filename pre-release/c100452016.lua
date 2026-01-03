--ヴァレルロード・Ｌ・ドラゴン
--Borreload Liberator Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 3+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--You can only Special Summon "Borreload Liberator Dragon(s)" once per turn
	c:SetSPSummonOnce(id)
	--Place 1 monster your opponent controls in a zone this card points to and take control of it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.controltg)
	e1:SetOperation(s.controlop)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_PHASE|TIMING_BATTLE_END)
	c:RegisterEffect(e1)
	--Destroy 1 monster you control and Special Summon itself from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_CHAIN_END)
	c:RegisterEffect(e2)
end
function s.controlfilter(c,zones)
	return c:IsControlerCanBeChanged(false,zones)
end
function s.controltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones=e:GetHandler():GetLinkedZone()&ZONES_MMZ
	if chk==0 then return Duel.IsExistingMatchingCard(s.controlfilter,tp,0,LOCATION_MZONE,1,nil,zones) end
	Duel.SetChainLimit(function(e,ep,tp) return tp==ep end)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.controlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones=c:GetLinkedZone()&ZONES_MMZ
	if not (c:IsRelateToEffect(e) and zones~=0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.controlfilter,tp,0,LOCATION_MZONE,1,1,nil,zones)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.GetControl(g,tp,0,0,zones)
	end
end
function s.desfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end