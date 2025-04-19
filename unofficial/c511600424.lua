--ユベル－Ｄａｓ　Ｅｘｔｒｅｍｅｒ　Ｔｒａｕｒｉｇ　Ｄｒａｃｈｅｎ (Anime)
--Yubel - The Ultimate Nightmare (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Opponent takes battle damage when this card attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Battle indestructible
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Destroy opponent's monster after battling
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--10 card hand limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_HAND_LIMIT)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(10)
	c:RegisterEffect(e4)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local at=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(at)
	return at
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end