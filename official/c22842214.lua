--シー・ランサー
--Sea Lancer
local s,id=GetID()
function s.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e1)
	--Destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.desreptg)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.atcon)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	local fc=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,fc,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
end
function s.equipop(c,e,tp,tc,chk)
	local eff=false or chk
	Duel.Equip(tp,tc,c,false,eff)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(aux.EquipByEffectLimit)
	e1:SetLabelObject(e:GetLabelObject())
	tc:RegisterEffect(e1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local tg=Group.CreateGroup()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		if ft>=#g then
			tg:Merge(g)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			tg:Merge(g:Select(tp,ft,ft,nil))
		end
	end
	g:Sub(tg)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		s.equipop(c,e,tp,tc,true)
	end
	Duel.EquipComplete()
	if #g>0 then
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
function s.eqfilter(c,ec)
	return c:GetFlagEffect(id)~=0 and c:IsHasCardTarget(ec)
end
function s.repfilter(c,e,ec)
	return s.eqfilter(c,ec) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local tc=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,c):GetFirst()
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	g:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
function s.atcon(e)
	return Duel.IsExistingMatchingCard(s.eqfilter,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler())
end
