--フレシアの蟲惑魔
--Traptrix Rafflesia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--Unaffected by Trap effects while it has material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e1:SetValue(function(e,te) return te:IsTrapEffect() end)
	c:RegisterEffect(e1)
	--"Traptrix" monsters you control, except "Traptrix Rafflesia", cannot be destroyed by battle or card effects
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(LOCATION_MZONE,0)
	e2a:SetTarget(function(e,c) return c:IsSetCard(SET_TRAPTRIX) and not c:IsCode(id) end)
	e2a:SetValue(1)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2b)
	--Your opponent cannot target "Traptrix" monsters you control, except "Traptrix Rafflesia", with card effects
	local e2c=e2a:Clone()
	e2c:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2c:SetValue(aux.tgoval)
	c:RegisterEffect(e2c)
	--This effect becomes that sent "Hole" Normal Trap's effect when that card is activated
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e3:SetCost(Cost.AND(Cost.DetachFromSelf(1),s.effcost))
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_TRAPTRIX,SET_TRAP_HOLE,SET_HOLE}
function s.copyfilter(c)
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE,SET_TRAP_HOLE}) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then
		--Storing the legal group before detaching due to rulings (Q&A #16286)
		local g=Duel.GetMatchingGroup(s.copyfilter,tp,LOCATION_DECK,0,nil)
		e:SetLabelObject(g)
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=e:GetLabelObject():Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(sc)
	Duel.SendtoGrave(sc,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
		return te and te:GetTarget() and te:GetTarget()(e,tp,ceg,cep,cev,cre,cr,crp,chk,chkc)
	end
	if chk==0 then
		local res=e:GetLabel()==-100
		e:SetLabel(0)
		return res
	end
	local sc=e:GetLabelObject()
	local te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		e:SetProperty(te:GetProperty())
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(0)
	e:SetLabelObject({te,ceg,cep,cev,cre,cr,crp})
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
	if not te then return end
	local op=te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e,tp,ceg,cep,cev,cre,cr,crp)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end
