--Quiz Panel - Obelisk 30
os = require('os')
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51101940,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.collection={
	[8062132]=true;[13893596]=true;[200000002]=true;[33396948]=true;[511000296]=true;
	[6165656]=true;[53334641]=true;[81171949]=true;[95308449]=true;[100100065]=true;
	[94212438]=true;[95000026]=true;[511001004]=true;[511000793]=true;[42776960]=true;
	[97795930]=true;[10000040]=true;[48995978]=true;[513000109]=true;
}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local endtime=0
	local check=true
	local start=os.time()
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,9))
	local ac1=Duel.AnnounceCard(1-tp)
	endtime=os.time()-start
	if endtime>10 or not s.collection[ac1] then
		check=false
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,9))
		local ac2=Duel.AnnounceCard(1-tp)
		endtime=os.time()-start
		if endtime>10 or not s.collection[ac1] or ac1==ac2 then
			check=false
		else
			Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,9))
			local ac3=Duel.AnnounceCard(1-tp)
			endtime=os.time()-start
			if endtime>10 or not s.collection[ac1] or ac1==ac3 or ac3==ac2 then
				check=false
			end
		end
	end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	if check==true then
		Duel.Damage(tp,1200,REASON_EFFECT)
	else
		if Duel.GetAttacker() then
			Duel.Destroy(Duel.GetAttacker(),REASON_EFFECT)
		end
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end
