--捕食植物モーレイ・ネペンテス
--Predaplant Moray Nepenthes
local s,id=GetID()
function s.initial_effect(c)
	--Gains 200 ATK for each Predator Counter on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return Duel.GetCounter(0,1,1,COUNTER_PREDATOR)*200 end)
	c:RegisterEffect(e1)
	--Equip an opponent's monster that was destroyed by battle with this card to this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsMonster),function(c,e,tp,bc) c:EquipByEffectAndLimitRegister(e,tp,bc,id) end,e2)
	--Destroy 1 Monster Card equipped to this card by this card's effect and gain LP equal to its ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.counter_list={COUNTER_PREDATOR}
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and bc:IsMonster() and bc:IsFaceup() end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,bc,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToEffect(e) and bc:IsMonster() and bc:IsFaceup() then
		e:GetHandler():EquipByEffectAndLimitRegister(e,tp,bc,id)
	end
end
function s.desfilter(c,ec)
	return c:HasFlagEffect(id) and c:GetEquipTarget()==ec and c:IsMonsterCard()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.desfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,0,1,1,nil,c)
	local atk=g:GetFirst():GetTextAttack()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	if atk>0 then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Recover(tp,tc:GetTextAttack(),REASON_EFFECT)
	end
end