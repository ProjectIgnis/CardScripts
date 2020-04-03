--Destiny Draw
--Scripted by Edo9300
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,0)
	--Destiny Draw
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(s.drcon)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_TO_DECK) 
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	c:RegisterEffect(e7)
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
	end)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_REMOVED,0,1,e:GetHandler(),id) then
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	else
		Duel.Remove(c,POS_FACEUP,REASON_RULE)
	end
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp,1,REASON_RULE)
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK+LOCATION_HAND,0)
	g:Remove(Card.IsOriginalCode,nil,id)
	if s[tp]==nil then
		s[tp]=Group.CreateGroup()
		s[tp]:KeepAlive()
		local i=0
		while i<5 and #g>0 and Duel.SelectYesNo(tp,529) do
			local tc=g:Select(tp,1,1,nil):GetFirst()
			local sg=g:Filter(Card.IsOriginalCode,nil,tc:GetOriginalCode())
			s[tp]:Merge(sg)
			g:Sub(sg)
			i=i+1
		end
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)/2 and Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)==0
		and	Duel.GetFieldGroupCount(e:GetHandler():GetControler(),0,LOCATION_MZONE)>0
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=s[tp]:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #g>0 and Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,65) then
		Duel.RegisterFlagEffect(tp,id,nil,0,1)
		Duel.Hint(HINT_CARD,0,id)
		local tc=g:RandomSelect(tp,1):GetFirst()
		Duel.MoveSequence(tc,0)
	end
end
