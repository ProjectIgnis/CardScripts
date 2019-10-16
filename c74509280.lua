--Sin パラレルギア
local s,id=GetID()
function s.initial_effect(c)
	--hand synchro
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetLabel(id)
	e3:SetValue(s.synval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	e4:SetValue(s.synfilter)
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
end
s.listed_series={0x23}
function s.synfilter(e,c)
	return c:IsLocation(LOCATION_HAND) and c:IsSetCard(0x23) and c:IsControler(e:GetHandlerPlayer())
end
function s.synval(e,c,sc)
	if c:IsSetCard(0x23) and c:IsLocation(LOCATION_HAND) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		e1:SetLabel(id)
		e1:SetTarget(s.synchktg)
		c:RegisterEffect(e1)
		return true
	else return false end
end
function s.chk2(c)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()==id then return true end
	end
	return false
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
	if c then
		local res=true
		if #sg>=2 or (not tg:IsExists(s.chk2,1,c) and not ntg:IsExists(s.chk2,1,c) 
			and not sg:IsExists(s.chk2,1,c)) then return false end
		local ttg=tg:Filter(s.chk2,nil)
		local nttg=ntg:Filter(s.chk2,nil)
		local trg=tg:Clone()
		local ntrg=ntg:Clone()
		trg:Sub(ttg)
		ntrg:Sub(nttg)
		return res,trg,ntrg
	else
		return #sg<2
	end
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return #sg==2,false
end
