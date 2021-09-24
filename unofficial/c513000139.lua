--邪神イレイザー (Manga)
--The Wicked Eraser (Manga)
--Scripted by MLD & Larry126, credit to TPD & Cybercatman
Duel.LoadScript("c421.lua")
local s,id=GetID()
function s.initial_effect(c)
	--summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c,true,false,3,3)
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
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetOperation(s.erasop)
	e5:SetLabel(0)
	c:RegisterEffect(e5)
	--"Divine Evolution (Manga)" check
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetRange(LOCATION_MZONE)
	e6:SetLabelObject(e5)
	e6:SetOperation(s.divevo)
	c:RegisterEffect(e6)
end
function s.adval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*1000
end
function s.erasop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local c=e:GetHandler()
	local divine_evo_label=e:GetLabel()
	if divine_evo_label==0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif divine_evo_label==1 then
		c:ResetFlagEffect(513000065)
		c:RegisterFlagEffect(513000065,0,0,0,2)
		Duel.SendtoGrave(g,REASON_EFFECT)
		c:ResetFlagEffect(513000065)
		e:SetLabel(0)
	end
end
function s.divevo(e,tp,eg,ev,ep,re,r,rp)
	local divine_hierarchy=e:GetHandler():GetFlagEffectLabel(513000065)
	if divine_hierarchy>1 then
		e:GetLabelObject():SetLabel(1)
	end
end
