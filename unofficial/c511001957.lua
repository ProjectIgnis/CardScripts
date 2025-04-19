--閃珖竜 スターダスト (Manga)
--Stardust Spark Dragon (Manga)
--updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.reptg)
	e1:SetValue(function(e,tc) return tc==e:GetLabelObject() end)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
function s.repfilter(c)
	return c:IsOnField() and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(s.repfilter,nil)
		local tc
		if #g==1 then
			tc=g:GetFirst()
		else
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
			tc=g:Select(tp,1,1,nil):GetFirst()
		end
		Duel.Hint(HINT_CARD,0,id)
		Duel.HintSelection(tc)
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetLabelObject():RegisterEffect(e1)
end