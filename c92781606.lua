--エクスクローラー・クオリアーク
--X-Krawler Qualiark
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x104),2,2)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(300)
	e2:SetCondition(s.effcon)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--actlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabel(4)
	e4:SetCondition(s.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--direct attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetLabel(6)
	e5:SetCondition(s.effcon)
	c:RegisterEffect(e5)
end
s.listed_series={0x104}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and g:GetClassCount(Card.GetCode)>1
	end
	local gp=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(gp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,gp,2,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 or ft<=0 or (#g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	if ft<#g then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,ft,ft,nil)
	end
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.effilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104)
end
function s.effcon(e)
	return Duel.GetMatchingGroupCount(s.effilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>=e:GetLabel()
end
function s.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return s.effcon(e) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end