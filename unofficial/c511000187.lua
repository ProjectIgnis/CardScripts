--アーマード・エクシーズ
--Armored Xyz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.eqfilter(c)
	return c:IsType(TYPE_XYZ) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
   	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
    	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)	
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    	local g=Duel.GetTargetCards(e)
    	if #g~=2 then return end
    	local tc=g:GetFirst()
    	local ec=g:GetNext()
    	if tc:IsLocation(LOCATION_GRAVE) then tc,ec=ec,tc end
    	if tc:IsFaceup() then
		if not Duel.Equip(tp,ec,tc,true) then return end
		--Equip limit
        	local e1=Effect.CreateEffect(c)
        	e1:SetType(EFFECT_TYPE_SINGLE)
        	e1:SetCode(EFFECT_EQUIP_LIMIT)
        	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        	e1:SetValue(s.eqlimit)
        	e1:SetLabelObject(tc)
        	ec:RegisterEffect(e1)
        	--Equipped monster name change
        	local e2=Effect.CreateEffect(c)
        	e2:SetType(EFFECT_TYPE_EQUIP)
        	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
        	e2:SetCode(EFFECT_CHANGE_CODE)
        	e2:SetValue(ec:GetOriginalCode())
        	ec:RegisterEffect(e2)
		--ATK change
        	local e3=Effect.CreateEffect(c)
        	e3:SetType(EFFECT_TYPE_EQUIP)
        	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
        	e3:SetCode(EFFECT_SET_ATTACK)
        	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        	e3:SetValue(ec:GetTextAttack())
        	ec:RegisterEffect(e3)
		--Attack again in a row
        	local e4=Effect.CreateEffect(c)
        	e4:SetDescription(aux.Stringid(id,0))
        	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
        	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        	e4:SetCountLimit(1)
        	e4:SetCode(EVENT_DAMAGE_STEP_END)
        	e4:SetRange(LOCATION_SZONE)
        	e4:SetCost(s.cost)
        	e4:SetTarget(s.atktg)
        	e4:SetOperation(s.atkop)
        	ec:RegisterEffect(e4)
    	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end
