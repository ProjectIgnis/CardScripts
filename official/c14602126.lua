--エクシーズ・インポート
--Xyz Import
--Scripted by Naim, updated by DyXel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_BATTLE_START)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
function s.atchfilter(c,atk)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and c:IsAttackBelow(atk)
end
function s.xyzfilter(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsType(TYPE_XYZ) and
		Duel.IsExistingTarget(s.atchfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local xyzc=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SelectTarget(tp,s.atchfilter,tp,0,LOCATION_MZONE,1,1,nil,xyzc:GetAttack())
	e:SetLabelObject(xyzc)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<=1 then return end
	local xyzc,tgc=(function()
		local c1=g:GetFirst()
		local c2=g:GetNext()
		if c1==e:GetLabelObject() then return c1,c2 else return c2,c1 end
	end)()
	if xyzc:IsRelateToEffect(e) and xyzc:IsControler(tp) and tgc:IsRelateToEffect(e) and tgc:IsControler(1-tp)
		and not xyzc:IsImmuneToEffect(e) and not tgc:IsImmuneToEffect(e) then
		Duel.Overlay(xyzc,tgc,true)
	end
end