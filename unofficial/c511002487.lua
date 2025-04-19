--幻奏の華歌聖ブルーム・ディーヴァ (Anime)
--Bloom Diva the Melodious Choir (Anime)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx2(Card.IsMelodiousSongtress),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MELODIOUS))
	--effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x9b}
s.material_setcode={0x9b,0x209b}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsSpecialSummoned() and bc:IsControler(1-tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE+RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE+RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLED)
		e3:SetOperation(s.desop)
		e3:SetLabelObject(c:GetBattleTarget())
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end