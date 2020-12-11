--アメイズメント・ファミリーフェイス
--Amazement Family Face
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,1,s.eqfilter,s.eqlimit,nil,s.target)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.condition)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--cannot trigger
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	--change archetype
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetValue(0x25d)
	e3:SetCondition(s.condition)
	c:RegisterEffect(e3)
end
s.listed_series={0x25d,0x25e}
function s.eqfilter(c,e,tp)
	return aux.CheckStealEquip(c) and c:GetEquipGroup():IsExists(s.eqcfilter,1,nil,tp)
end
function s.eqcfilter(c,tp)
	return c:IsSetCard(0x25e) and c:IsType(TYPE_TRAP) and c:IsControler(tp)
end
function s.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc)
	e:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.condition(e)
	local c=e:GetHandler()
	return c:GetControler()==e:GetHandlerPlayer()
end
