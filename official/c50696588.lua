--ＧＵＹダンス
--GUY Dance
--Scripted by Eerie Code and edo9300
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 end
	local zone=Duel.SelectDisableField(1-tp,1,LOCATION_MZONE,0,~(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)>>16))
	e:SetLabel(zone)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	local nseq=math.log(zone,2)
	if not Duel.CheckLocation(1-tp,LOCATION_MZONE,nseq) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(zone|0x60)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.adjop)
	e2:SetLabel(nseq)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
end
function s.adjop(e,tp,eg,ep,ev,re,r,rp)
	local nseq=e:GetLabel()
	if not Duel.CheckLocation(1-tp,LOCATION_MZONE,nseq) then
		e:GetLabelObject():Reset()
		e:Reset()
	end
end
