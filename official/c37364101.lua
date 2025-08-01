--ストイック・チャレンジ
--Stoic Challenge
local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Stoic Challenge"
	c:SetUniqueOnField(1,0,id)
	--Equip only to a face-up Xyz Monster that has Xyz Material
	aux.AddEquipProcedure(c,nil,function(c) return c:IsXyzMonster() and c:GetOverlayCount()>0 end)
	--It gains 600 ATK for each Xyz Material attached to a monster you control
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_EQUIP)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetValue(function(e,c) return Duel.GetOverlayCount(e:GetHandlerPlayer(),1,0)*600 end)
	c:RegisterEffect(e1a)
	--And any battle damage your opponent takes from battles involving it and their monster is doubled
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_EQUIP)
	e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1b:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1b:SetCondition(function(e) local bc=e:GetHandler():GetEquipTarget():GetBattleTarget() return bc and bc:IsControler(1-e:GetHandlerPlayer()) end)
	e1b:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1b)
	--But its effects cannot be activated
	local e1c=Effect.CreateEffect(c)
	e1c:SetType(EFFECT_TYPE_EQUIP)
	e1c:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1c:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e1c)
	--Send this card to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--When this card leaves the field, destroy the equipped monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end