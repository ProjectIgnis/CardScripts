--ガラスの靴 (Anime)
--Glass Slippers (Anime)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--change equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	--Atk up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(-1000)
	e4:SetCondition(s.atkcon)
	c:RegisterEffect(e4)
	--at limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(s.atkcon)
	e5:SetTarget(s.attg)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	--reequip to Cinderella
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(s.eqcon2)
	e6:SetTarget(s.eqtg2)
	e6:SetOperation(s.eqop)
	c:RegisterEffect(e6)
end
s.listed_names={78527720}
function s.filter(c,e,tp)
	return c:IsCode(78527720) or c:GetControler()~=tp
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	return ep~=tp and eq and eq:IsCode(78527720) and eg:GetFirst()==eq
end
function s.atkcon(e)
	local eq=e:GetHandler():GetEquipTarget()
	return eq and eq:GetControler()~=e:GetHandlerPlayer()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,0,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc)
	else
		Duel.SendtoGrave(c,REASON_EFFECT) 
	end
end
function s.attg(e,c)
	return c==e:GetHandler():GetEquipTarget() and not c:IsImmuneToEffect(e)
end
function s.atkval(e,c)
	return c:IsCode(78527720)
end
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and e:GetHandler():GetPreviousEquipTarget():IsReason(REASON_DESTROY)
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end