--魅惑の女王 LV7
--Allure Queen LV7
local s,id=GetID()
function s.initial_effect(c)
	--Register if this card is Special Summoned by "Alure Queen LV5"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
end
s.listed_names={23756165} --Alure Queen LV5
s.LVnum=7
s.LVset=SET_ALLURE_QUEEN
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSummonType()==SUMMON_TYPE_SPECIAL+1 then
		--Equip 1 monster your opponent controls to this card
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_EQUIP)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetCondition(s.eqcon)
		e1:SetTarget(s.eqtg)
		e1:SetOperation(s.eqop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		aux.AddEREquipLimit(c,s.eqcon1,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop,e1,nil,RESET_EVENT|RESETS_STANDARD_DISABLE)
		--Quick Effect, if you are affected by "Golden Allure Queen"
		local e2=e1:Clone()
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetHintTiming(0,TIMING_END_PHASE)
		e2:SetCondition(s.eqcon2)
		c:RegisterEffect(e2)
		aux.AddEREquipLimit(c,s.eqcon2,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop,e2,nil,RESET_EVENT|RESETS_STANDARD_DISABLE)
	end
end
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id)
	return #g==0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_GOLDEN_ALLURE_QUEEN)
end
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id)
	return #g==0 and Duel.IsPlayerAffectedByEffect(tp,CARD_GOLDEN_ALLURE_QUEEN)
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
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.repval)
	tc:RegisterEffect(e1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end
function s.repval(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end