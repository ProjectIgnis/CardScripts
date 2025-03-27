--呪いのお札
--Cursed Bill
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	if not ec then return end
	e:SetLabelObject(ec)
	e:SetLabel(ec:GetPreviousControler())
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_DESTROY)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetLabelObject():GetTextDefense()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(e:GetLabel())
	Duel.SetTargetParam(dam)
	Duel.SetTargetCard(e:GetLabelObject())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetLabel(),dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,g:GetFirst():GetTextDefense(),REASON_EFFECT)
	end
end