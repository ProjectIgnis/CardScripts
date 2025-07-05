--ＣＮｏ．６ 先史遺産カオス・アトランタル
--Number C6: Chronomaly Chaos Atlandis
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 7 monsters
	Xyz.AddProcedure(c,nil,7,3)
	--Equip 1 monster your opponent controls to this card as an Equip Spell Card whose effect makes this monster gain 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop,e1)
	--Make your opponent's Life Points 100
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp) return Duel.GetLP(1-tp)~=100 and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,9161357) end)
	e2:SetCost(Cost.AND(Cost.Detach(3),s.lpcost))
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}
s.xyz_number=6
s.listed_names={9161357}
function s.nodamage(e,tp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--Your opponent takes no further damage this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	--Equipped monster gains 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(1000)
	tc:RegisterEffect(e1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
	s.nodamage(e,tp)
end
function s.lpcostfilter(c)
	return c:HasFlagEffect(id) and c:IsSetCard(SET_NUMBER) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqg=e:GetHandler():GetEquipGroup():Filter(s.lpcostfilter,nil)
	if chk==0 then return #eqg>0 end
	Duel.SendtoGrave(eqg,REASON_COST)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(1-tp,100)
	s.nodamage(e,tp)
end
