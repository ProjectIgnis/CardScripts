--召喚獣オーケアノス
--Invoked Okeanos
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Naterials: 1 "Aleister" monster + 1 DARK or WATER monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ALEISTER),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK|ATTRIBUTE_WATER))
	--While this card is in the Main Monster Zone, your opponent's monsters cannot target monsters for attacks, except this one
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MMZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(function(e,c) return c~=e:GetHandler() end)
	c:RegisterEffect(e1)
	--While this card is in the Extra Monster Zone, any monster sent to your opponent's GY is banished instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_EMZONE)
	e2:SetTarget(s.rmtarget)
	e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	--You can banish this card from your GY, then target 1 Fusion Monster you control; it can attack directly this turn. You can only use this effect of "Invoked Okeanos" once per turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp) return Duel.IsAbleToEnterBP() end)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.diratktg)
	e3:SetOperation(s.diratkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ALEISTER}
s.material_setcode={SET_ALEISTER}
function s.rmtarget(e,c)
	local tp=e:GetHandlerPlayer()
	return not (c:IsOwner(tp) or c:IsSpellTrap() or c:IsLocation(LOCATION_OVERLAY)) and Duel.IsPlayerCanRemove(tp,c)
end
function s.diratktgfilter(c)
	return c:IsFusionMonster() and c:IsFaceup() and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
function s.diratktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.diratktgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.diratktgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.diratktgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.diratkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--It can attack directly this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3205)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end