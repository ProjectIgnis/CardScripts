--トラップ・ギャザー
--Trap Gatherer
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--The equipped monster gains 400 ATK for each Trap in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(function(e) return Duel.GetMatchingGroupCount(Card.IsTrap,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*400 end)
	c:RegisterEffect(e1)
	--Set 1 Trap from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetCost(Cost.SelfToGrave)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Banish this card you control instead of a face-up Trap(s) you control being destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.reptg)
	e3:SetOperation(function(e) Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE) end)
	e3:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	local bc=ec:GetBattleTarget()
	local ex,_,damp=Duel.CheckEvent(EVENT_BATTLE_DAMAGE,true)
	return (bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsControler(1-tp)) or (ex and damp==1-tp)
end
function s.setfilter(c,ignore_zones)
	return c:IsTrap() and c:IsSSetable(ignore_zones)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil,true) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,false)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and c:IsTrap() and c:IsFaceup()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end