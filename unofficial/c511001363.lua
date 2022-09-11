--CX 冀望皇バリアン (Anime)
--CXyz Barian Hope (Anime)
--Rescripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,7,3,nil,nil,99)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(0xff&~LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.xyztg)
	e1:SetValue(s.xyzval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetValue(s.xyzlv)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--copy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(id)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		--Copy
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCondition(s.con)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x1048}
function s.cfilter(c)
	return c:IsHasEffect(511002571) and c:GetFlagEffect(5110013630)==0
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_ALL,LOCATION_ALL,1,nil)
end
function s.op(e)
	local g=Duel.GetMatchingGroup(s.cfilter,0,LOCATION_ALL,LOCATION_ALL,nil)
	for c in aux.Next(g) do
		local effs={c:GetCardEffect(511002571)}
		for _,eff in ipairs(effs) do
			local te=eff:GetLabelObject()
			if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
			local resetflag,resetcount=te:GetReset()
			local rm,max,code,flag,hopt=te:GetCountLimit()
			local prop1,prop2=te:GetProperty()
			local e1=Effect.CreateEffect(c)
			if te:GetDescription() then
				e1:SetDescription(te:GetDescription())
			end
			e1:SetLabelObject(te)
			e1:SetType(EFFECT_TYPE_XMATERIAL+te:GetType()&(~EFFECT_TYPE_SINGLE))
			if te:GetCode()>0 then
				e1:SetCode(te:GetCode())
			end
			e1:SetProperty(prop1|EFFECT_FLAG_CARD_TARGET,prop2)
			e1:SetCondition(s.copycon)
			e1:SetCost(s.copycost)
			if max>0 then
				e1:SetCountLimit(max,{code,hopt},flag)
			end
			if te:GetTarget() then
				e1:SetTarget(te:GetTarget())
			end
			if te:GetOperation() then
				e1:SetOperation(te:GetOperation())
			end
			if resetflag>0 and resetcount>0 then
				e1:SetReset(resetflag,resetcount)
			elseif resetflag>0 then
				e1:SetReset(resetflag)
			end
			c:RegisterEffect(e1,true)
			c:RegisterFlagEffect(5110013630,resetflag,prop1,resetcount)
		end
	end
end
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	local con=e:GetLabelObject():GetCondition()
	return e:GetHandler():IsHasEffect(id) and Duel.GetTurnPlayer()==tp
		and e:GetOwner():GetFlagEffect(id)==0
		and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetOwner()
	local a=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b=Duel.CheckLPCost(tp,400)
	if chk==0 then return a or b end
	Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
	Duel.SetTargetCard(tc)
	local op=Duel.SelectEffect(tp,{a,aux.Stringid(81330115,0)},{b,aux.Stringid(21454943,1)})
	if op==0 then
		Duel.SendtoGrave(tc,REASON_COST) 
	else
		Duel.PayLPCost(tp,400)
	end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.xyztg(e,c)
	local no=c.xyz_number
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(0x1048)
end
function s.xyzval(e,c,rc,tp)
	return rc==e:GetOwner()
end
function s.xyzlv(e,c,rc)
	if rc==e:GetOwner() then
		return 7,e:GetHandler():GetLevel()
	else
		return e:GetHandler():GetLevel()
	end
end
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
