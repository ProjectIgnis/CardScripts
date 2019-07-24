--The Wicked Eraser (Anime)
--邪神イレイザー
--マイケル・ローレンス・ディーによってスクリプト
--scripted by MLD
--credit to TPD & Cybercatman
--updated by Larry126
Duel.LoadScript("c421.lua")
local s,id=GetID()
function s.initial_effect(c)
	--summon with 3 tribute
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e4)
	--Eraser
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(57793869,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetTarget(s.erastg)
	e5:SetOperation(s.erasop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(0xff&~LOCATION_GRAVE)
	e6:SetLabelObject(e5)
	e6:SetOperation(s.op)
	c:RegisterEffect(e6)
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetFlagEffectLabel(513000065))
end
function s.ttcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-3 and Duel.GetTributeCount(c)>=3
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
function s.adval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*1000
end
function s.erastg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.erasop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local c=e:GetHandler()
	local phr=e:GetLabel()
	local hr=c:GetFlagEffectLabel(513000065)
	if phr~=hr then
		if phr then
			c:ResetFlagEffect(513000065)
			c:RegisterFlagEffect(513000065,0,0,0,phr)
			Duel.SendtoGrave(g,REASON_EFFECT)
			c:ResetFlagEffect(513000065)
			if hr then
				c:RegisterFlagEffect(513000065,0,0,0,hr)
			end
		else
			c:ResetFlagEffect(513000065)
			Duel.SendtoGrave(g,REASON_EFFECT)
			if hr then
				c:RegisterFlagEffect(513000065,0,0,0,hr)
			end
		end
	else
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end