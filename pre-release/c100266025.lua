--Ｎｏ．４ ゲート・オブ・ヌメロン－チャトゥヴァーリ
--Number 4: Numeron Gate Catvari
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	--cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--attack up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.NumeronDetachCost(1))
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={0x246}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x246),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,1)
		tc:RegisterEffect(e1)
	end
end
