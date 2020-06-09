--Ｕ．Ａ．マン・オブ・ザ・マッチ
--U.A. MVP
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add setcode
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x107)
	c:RegisterEffect(e0)
	--Special Summon when destroying by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon when inflicting battle damage
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.dmcon)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x107,0xb2}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return (a:IsSetCard(0x107) or a:IsSetCard(0xb2)) and not a:IsStatus(STATUS_BATTLE_DESTROYED)
		and d:IsStatus(STATUS_BATTLE_DESTROYED)
end
--[[
function s.cfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:IsReason(REASON_BATTLE) and rc:IsRelateToBattle() and rc:IsControler(tp) and (rc:IsSetCard(0x107) or rc:IsSetCard(0xb2))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
]]
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and (c:IsSetCard(0x107) or c:IsSetCard(0xb2))
end
function s.sprescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)>=#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE+LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
	if #tg==0 or ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=aux.SelectUnselectGroup(tg,e,tp,1,ft,s.sprescon,1,tp,HINTMSG_SPSUMMON)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep==1-tp and tc:IsControler(tp) and (tc:IsSetCard(0x107) or tc:IsSetCard(0xb2))
end