--百景戦都ゴルディロックス
--Landscaper Goldilocks
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--self destroy on summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--move
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(aux.NOT(s.descon))
	e4:SetValue(3000)
	c:RegisterEffect(e4)
end
function s.descon(e)
	return e:GetHandler():GetSequence()~=2
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,seq)
	e:SetLabel(math.log(seq,2))
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local seq2=e:GetLabel()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) or not Duel.CheckLocation(tp,LOCATION_MZONE,seq2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq1=c:GetSequence() --register the sequence it comes from
	local dg=c:GetColumnGroup() --and the group of cards there
	Duel.MoveSequence(c,seq2)
	if c:GetSequence()==seq2 and seq1~=seq2 then
		Duel.BreakEffect()
		local diff=math.abs(seq1-seq2)
		if seq1>seq2 then
			dg:Merge(c:GetColumnGroup(nil,diff))
		else
			dg:Merge(c:GetColumnGroup(diff,nil))
		end
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

