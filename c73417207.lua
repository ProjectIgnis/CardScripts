--極星霊スヴァルトアールヴ
function c73417207.initial_effect(c)
	--hand synchro
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetLabel(73417207)
	e3:SetValue(c73417207.synval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	e4:SetValue(c73417207.synfilter)
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetOperation(c73417207.synop)
	c:RegisterEffect(e1)
end
function c73417207.synfilter(e,c)
	return c:IsLocation(LOCATION_HAND) and c:IsSetCard(0x42) and c:IsControler(e:GetHandlerPlayer())
end
function c73417207.synval(e,c,sc)
	if c:IsSetCard(0x42) and c:IsLocation(LOCATION_HAND) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		e1:SetLabel(73417207)
		e1:SetTarget(c73417207.synchktg)
		c:RegisterEffect(e1)
		return true
	else return false end
end
function c73417207.chk2(c)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()==73417207 then return true end
	end
	return false
end
function c73417207.filterchk(c)
	if c:IsSetCard(0x42) then return false end
	return not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) 
		or c:GetCardEffect(EFFECT_HAND_SYNCHRO):GetLabel()~=73417207
end
function c73417207.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
	if c then
		local res=true
		if sg:GetCount()>=3 or (not tg:IsExists(c73417207.chk2,1,c) and not ntg:IsExists(c73417207.chk2,1,c) 
			and not sg:IsExists(c73417207.chk2,1,c)) then return false end
		local trg=tg:Filter(c73417207.filterchk,nil)
		local ntrg=ntg:Filter(c73417207.filterchk,nil)
		return res,trg,ntrg
	else
		return sg:GetCount()<3
	end
end
function c73417207.synop(e,tg,ntg,sg,lv,sc,tp)
	return sg:GetCount()==3,false
end
